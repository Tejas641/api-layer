import { combineReducers } from 'redux';
import tilesReducer from './fetch-tile-reducer';
import filtersReducer from './filter-reducer';
import loadingReducer from './loading-reducer';
import errorReducer from './error-reducer';
import authenticationReducer from './authentication-reducer';
import selectedServiceReducer from './selected-service-reducer';
import refreshStaticApisReducer from './refresh-static-apis-reducer';
import serviceVersionDiff from './service-version-diff-reducer';

const reducers = {
    filtersReducer,
    tilesReducer,
    loadingReducer,
    errorReducer,
    authenticationReducer,
    selectedServiceReducer,
    refreshStaticApisReducer,
    serviceVersionDiff,
};

// eslint-disable-next-line import/prefer-default-export
export const rootReducer = combineReducers(reducers);
